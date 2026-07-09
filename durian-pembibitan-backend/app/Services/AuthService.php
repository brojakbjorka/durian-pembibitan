<?php

namespace App\Services;

use App\Repositories\Contracts\UserRepositoryInterface;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthService
{
    protected UserRepositoryInterface $userRepository;
    protected AuditTrailService $auditTrailService;

    public function __construct(UserRepositoryInterface $userRepository, AuditTrailService $auditTrailService)
    {
        $this->userRepository = $userRepository;
        $this->auditTrailService = $auditTrailService;
    }

    /**
     * Authenticate user and return token.
     */
    public function login(array $credentials)
    {
        $user = $this->userRepository->findByEmail($credentials['email']);

        if (!$user || !Hash::check($credentials['password'], $user->password)) {
            // Log failed login
            $this->auditTrailService->log('Gagal Login', 'Auth', null, 'Gagal');
            throw ValidationException::withMessages([
                'email' => ['Kredensial yang diberikan salah.'],
            ]);
        }

        // Create token
        $token = $user->createToken('nursery_auth_token')->plainTextToken;

        // Log successful login
        // Resolve temporary Auth user session to log correctly
        auth()->login($user);
        $this->auditTrailService->log('Login', 'Auth', $user->id, 'Sukses');

        return [
            'user' => $user,
            'token' => $token,
        ];
    }

    /**
     * Logout currently authenticated user.
     */
    public function logout($user)
    {
        if ($user) {
            $user->currentAccessToken()->delete();
            $this->auditTrailService->log('Logout', 'Auth', $user->id, 'Sukses');
        }
    }

    /**
     * Update user profile.
     */
    public function updateProfile($user, array $data)
    {
        return $this->userRepository->update($user->id, [
            'name' => $data['name'],
            'email' => $data['email'],
        ]);
    }

    /**
     * Update user password.
     */
    public function updatePassword($user, string $currentPassword, string $newPassword)
    {
        if (!Hash::check($currentPassword, $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['Kata sandi saat ini salah.'],
            ]);
        }

        return $this->userRepository->update($user->id, [
            'password' => Hash::make($newPassword),
        ]);
    }
}

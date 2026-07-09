<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\UpdateProfileRequest;
use App\Http\Requests\UpdatePasswordRequest;
use App\Http\Resources\UserResource;
use App\Services\AuthService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    use ApiResponse;

    protected AuthService $authService;

    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
    }

    /**
     * User login.
     */
    public function login(LoginRequest $request)
    {
        $result = $this->authService->login($request->validated());

        return $this->successResponse([
            'user' => new UserResource($result['user']),
            'token' => $result['token'],
        ], 'Login berhasil.');
    }

    /**
     * User logout.
     */
    public function logout(Request $request)
    {
        $this->authService->logout($request->user());

        return $this->successResponse(null, 'Logout berhasil.');
    }

    /**
     * Get authenticated user profile.
     */
    public function profile(Request $request)
    {
        return $this->successResponse(new UserResource($request->user()), 'Data profil berhasil diambil.');
    }

    /**
     * Update user profile.
     */
    public function updateProfile(UpdateProfileRequest $request)
    {
        $user = $request->user();
        $updatedUser = $this->authService->updateProfile($user, $request->validated());

        return $this->successResponse(new UserResource($updatedUser), 'Profil berhasil diperbarui.');
    }

    /**
     * Update user password.
     */
    public function updatePassword(UpdatePasswordRequest $request)
    {
        $user = $request->user();
        $validated = $request->validated();

        $this->authService->updatePassword(
            $user,
            $validated['current_password'],
            $validated['new_password']
        );

        return $this->successResponse(null, 'Kata sandi berhasil diperbarui.');
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\UserStoreRequest;
use App\Http\Requests\UserUpdateRequest;
use App\Http\Resources\UserResource;
use App\Services\UserService;
use App\Traits\ApiResponse;

class UserController extends Controller
{
    use ApiResponse;

    protected UserService $userService;

    public function __construct(UserService $userService)
    {
        $this->userService = $userService;
    }

    public function index()
    {
        $users = $this->userService->getAll();
        return $this->successResponse(UserResource::collection($users), 'Daftar pengguna berhasil diambil.');
    }

    public function store(UserStoreRequest $request)
    {
        $user = $this->userService->create($request->validated());
        return $this->successResponse(new UserResource($user), 'Pengguna berhasil dibuat.', 201);
    }

    public function show(string|int $id)
    {
        $user = $this->userService->getById($id);
        return $this->successResponse(new UserResource($user), 'Detail pengguna berhasil diambil.');
    }

    public function update(UserUpdateRequest $request, string|int $id)
    {
        $user = $this->userService->update($id, $request->validated());
        return $this->successResponse(new UserResource($user), 'Pengguna berhasil diperbarui.');
    }

    public function destroy(string|int $id)
    {
        $this->userService->delete($id);
        return $this->successResponse(null, 'Pengguna berhasil dihapus.');
    }
}

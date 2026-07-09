<?php

namespace App\Repositories\Eloquent;

use App\Repositories\Contracts\RepositoryInterface;
use Illuminate\Database\Eloquent\Model;

class BaseRepository implements RepositoryInterface
{
    protected Model $model;

    public function __construct(Model $model)
    {
        $this->model = $model;
    }

    public function all()
    {
        return $this->model->all();
    }

    public function find(string|int $id)
    {
        return $this->model->findOrFail($id);
    }

    public function create(array $data)
    {
        return $this->model->create($data);
    }

    public function update(string|int $id, array $data)
    {
        $record = $this->find($id);
        $record->update($data);
        return $record;
    }

    public function delete(string|int $id)
    {
        $record = $this->find($id);
        return $record->delete();
    }

    public function findWithTrashed(string|int $id)
    {
        if (method_exists($this->model, 'withTrashed')) {
            return $this->model->withTrashed()->findOrFail($id);
        }
        return $this->find($id);
    }

    public function restore(string|int $id)
    {
        $record = $this->findWithTrashed($id);
        if (method_exists($record, 'restore')) {
            return $record->restore();
        }
        return false;
    }
}

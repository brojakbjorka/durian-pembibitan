<?php

namespace App\Repositories\Eloquent;

use App\Models\KatalogDaun;
use App\Repositories\Contracts\KatalogDaunRepositoryInterface;

class KatalogDaunRepository extends BaseRepository implements KatalogDaunRepositoryInterface
{
    public function __construct(KatalogDaun $model)
    {
        parent::__construct($model);
    }

    public function findByVarietas(string $varietas)
    {
        return $this->model->where('varietas', $varietas)->first();
    }
}

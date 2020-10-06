#!/usr/bin/env bash

mkdir -p volumes/insightface

# this requires nvidia runtime set as default
docker-compose run --rm -v "${DATA_DIR:-./volumes}/insightface:/root/.insightface" insightface\
  python3 -c "from insightface.model_zoo.face_recognition import get_arcface; get_arcface('r100_v1')"
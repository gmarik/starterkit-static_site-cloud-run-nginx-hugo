#!/bin/sh

set -uxe

cache_warmup() {
  docker pull ${_SITE_IMG_LATEST} || exit 0
}

hugo_build_image() {
  docker build -t ${_HUGO_IMG} \
    -f hugo/hugo.Dockerfile hugo/ \
    --build-arg HUGO_VERSION=${_HUGO_VERSION}

  docker push ${_HUGO_IMG}
}

hugo_compile() {
  docker run -w /site -v $PWD:/site ${_HUGO_IMG} -s ./src --minify
  # hugo -s ./src --minify
}

image_build() {
  docker build \
    --cache-from ${_SITE_IMG_LATEST} \
    --build-arg SITE=site01 \
    --build-arg SRC=site01.content \
    -t ${_SITE_IMG} \
    -t ${_SITE_IMG_LATEST} \
    -f nginx/nginx.Dockerfile \
    .
}

image_push() {
  docker push ${_SITE_IMG}
}

site_image_build() {
  cache_warmup
  image_build
  image_push
}

site_cloud_run_deploy() {
  gcloud -q beta \
    run deploy $CLOUD_RUN_PROJECT_NAME \
      --platform managed \
      --region us-central1 \
      --image ${_SITE_IMG}
}

$@

sudo docker build --build-arg GITHUB_OAUTH_TOKEN=${GITHUB_OAUTH_TOKEN} -t t3nsor/jupyterlab-plugin-gpu:tensorflow2 -f Dockerfile .

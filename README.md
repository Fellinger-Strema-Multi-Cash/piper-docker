
## Build
```
just docker-build
```

#### Download voices for piper-tts docker image
```
cd multicash/contrib/docker/regtest
mkdir --parents ./data/piper-data

docker run -it --rm -v ./data/piper-data:/data piper-tts download en_US-lessac-medium
docker run -it --rm -v ./data/piper-data:/data piper-tts download de_DE-thorsten-high
docker run -it --rm -v ./data/piper-data:/data piper-tts download en_GB-cori-high
docker run -it --rm -v ./data/piper-data:/data piper-tts download it_IT-paola-medium
docker run -it --rm -v ./data/piper-data:/data piper-tts download es_ES-davefx-medium
```

## Start
```
just docker-run
```

# Resources

- Piper API docs: https://thedocs.io/piper1-gpl/api/http/
- Piper Docker docs: https://thedocs.io/piper1-gpl/usage/docker/

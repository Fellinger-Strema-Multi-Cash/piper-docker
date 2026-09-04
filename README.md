# piper-docker

## Usage Notes
```sh
docker pull ghcr.io/fellinger-strema-multi-cash/piper:latest
```

### Environment variables

The following environment variables control the configuration:

- `MC_PORT` (optional; api port; default: `5000`)
- `MC_MODEL` (optional; default model; default: `en_US-lessac-medium`)
- `MC_ADDITIONAL_CMD_ARGS` (optional; additional cmd args)

## Build
```sh
just docker-build
```

## Start
```sh
just docker-run
```
or
```sh
docker compose up
```

## Test
```sh
# creates an .mp3 file in the test/ directory
just test-speech
```
or
```sh
curl --request POST \
    --header "Content-Type: application/json" \
    --data "{ \
      \"text\": \"This is a test.\",\
      \"voice\": \"en_US-lessac-medium\",\
      \"length_scale\": 1,\
      \"noise_scale\": 0.667,\
      \"length_w_scale\": 0.8\
    }" \
    --output test/test.wav \
    http://localhost:5000/synthesize
```

## Misc

Execute `just` to see all available commands.
```sh
$> just
Available recipes:
    [development]
    # text to speech
    test-speech voice="en_US-lessac-medium" text="This is a test."
    test-speech-de_DE text="Das ist ein Test."   # text to speech test in German
    test-speech-en_US text="This is a test."     # text to speech test in English (US)
    test-speech-es_ES text="Esto es una prueba." # text to speech test in Spanish
    test-speech-it_IT text="Questo è un test."   # text to speech test in Italian

    [docker]
    # create docker image
    docker-build piper_repo_ref=env('PIPER_REPO_REF') *args=''
    docker-run port="5000"                       # run container
    docker-run-shell                             # run shell in docker container

    [project-agnostic]
    default                                      # print available targets
    evaluate                                     # evaluate and print all just variables
    system-info                                  # print system information such as OS and architecture
```

# Resources
- Piper (GitHub): https://github.com/OHF-Voice/piper1-gpl
- Piper API docs: https://thedocs.io/piper1-gpl/api/http/
- Piper Docker docs: https://thedocs.io/piper1-gpl/usage/docker/
- Piper Voices: https://huggingface.co/rhasspy/piper-voices/tree/main

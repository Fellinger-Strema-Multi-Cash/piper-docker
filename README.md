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
```
just docker-build
```

## Start
```
just docker-run
```
or
```
docker compose up
```

```
curl --request POST \
    --header 'Content-Type: application/json' \
    --data '{ \
      "text": "This is a test.",\
      "voice": "en_US-lessac-medium",\
      "length_scale": 1,\
      "noise_scale": 0.667,\
      "length_w_scale": 0.8\
    }' \
    --output test/test-{{ voice }}.wav \
    http://localhost:5000/synthesize
```

# Resources

- Piper API docs: https://thedocs.io/piper1-gpl/api/http/
- Piper Docker docs: https://thedocs.io/piper1-gpl/usage/docker/
- Piper Voices: https://huggingface.co/rhasspy/piper-voices/tree/main

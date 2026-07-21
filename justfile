# This justfile requires https://github.com/casey/just

set shell := ["bash", "-c"]

# Load environment variables from `.env` file.
set dotenv-load
# Fail the script if the env file is not found.
set dotenv-required

project_dir := justfile_directory()

# print available targets
[group("project-agnostic")]
default:
    @just --list --justfile {{justfile()}}

# evaluate and print all just variables
[group("project-agnostic")]
evaluate:
    @just --evaluate

# print system information such as OS and architecture
[group("project-agnostic")]
system-info:
    @echo "architecture: {{arch()}}"
    @echo "os: {{os()}}"
    @echo "os family: {{os_family()}}"

# create "ui" docker image
[group("docker")]
docker-build piper_repo_ref=env('PIPER_REPO_REF') *args='':
    @echo "Creating docker image ..."
    @docker build {{args}} \
        --label "local" \
        --build-arg PIPER_REPO_REF={{piper_repo_ref}} \
        --tag "multicash/piper-local" .

# run shell in docker container
[group("docker")]
docker-run:
    @docker run --rm --publish 5000:5000 multicash/piper-local 


# run shell in docker container
[group("docker")]
docker-run-shell:
    @docker run --rm --entrypoint="/bin/bash" -it multicash/piper-local


# text to speech
[group("development")]
test-speech voice="en_US-lessac-medium" text="This is a test.":
    curl --request POST \
      --header 'Content-Type: application/json' \
      --data '{ \
        "text": "{{ text }}",\
        "voice": "{{ voice }}",\
        "length_scale": 1.1,\
        "noise_scale": 0.667,\
        "length_w_scale": 0.8\
      }' \
      --output test/test-{{ voice }}.wav \
      http://localhost:5000/synthesize
    @just convert-wav-to-mp3 test/test-{{ voice }}.wav test/test-{{ voice }}.mp3
    @rm --force test/test-{{ voice }}.wav

# text to speech test in English (US)
[group("development")]
test-speech-en_US text="This is a test.":
    @just test-speech en_US-lessac-medium "{{ text }}"

# text to speech test in English (GB)
[group("development")]
test-speech-en_GB text="This is a test.":
    @just test-speech en_GB-cori-high "{{ text }}"

# text to speech test in Spanish
[group("development")]
test-speech-es_ES text="Esto es una prueba.":
    @just test-speech es_ES-davefx-medium "{{ text }}"

# text to speech test in German
[group("development")]
test-speech-de_DE text="Das ist ein Test.":
    @just test-speech de_DE-thorsten-high "{{ text }}"

# text to speech test in Italian
[group("development")]
test-speech-it_IT text="Questo è un test.":
    @just test-speech it_IT-paola-medium "{{ text }}"

# convert wav to mp3
[private]
[group("devtools")]
convert-wav-to-mp3 input output:
    @ffmpeg -i {{ input }} {{ output }} -v quiet -y

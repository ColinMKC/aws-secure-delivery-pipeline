# TODO (Stage 4): pin by digest, e.g. public.ecr.aws/lambda/python:3.12@sha256:<digest>
FROM public.ecr.aws/lambda/python:3.12

# T4: apply OS security fixes the base image hasn't picked up yet (openssl, pcre2, rpm).
# Trade-off: less reproducible builds; revisit once the base image is digest-pinned.
RUN dnf -y upgrade && dnf clean all

# T4: the Runtime Interface Emulator is only for local testing; Lambda never runs it.
# Removing it drops a binary flagged by Trivy and shrinks the attack surface.
RUN rm -f /usr/local/bin/aws-lambda-rie

COPY app.py ${LAMBDA_TASK_ROOT}/

# T4: never run as root (numeric UID; base image has no useradd)
USER 1000:1000
CMD ["app.handler"]

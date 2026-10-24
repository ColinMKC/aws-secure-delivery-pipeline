# TODO (Stage 4): pin by digest, e.g. public.ecr.aws/lambda/python:3.12@sha256:<digest>
# Tags are mutable; digests are not (same lesson as pinning Actions to SHAs).
FROM public.ecr.aws/lambda/python:3.12
COPY app.py ${LAMBDA_TASK_ROOT}/
CMD ["app.handler"]

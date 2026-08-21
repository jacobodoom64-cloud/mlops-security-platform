FROM public.ecr.aws/lambda/python:3.12

# Install dependencies first, as a separate layer.
# Docker caches this, so changing app.py later does not
# trigger a reinstall of PyTorch.
COPY requirements.txt ${LAMBDA_TASK_ROOT}/
RUN pip install --no-cache-dir -r ${LAMBDA_TASK_ROOT}/requirements.txt

# Bake the model into the image at build time.
# Downloading at runtime would add 20-30s to every cold start
# and require outbound internet access from Lambda.
ENV HF_HOME=/opt/hf
RUN python -c "\
from transformers import pipeline; \
pipeline('sentiment-analysis', \
         model='distilbert-base-uncased-finetuned-sst-2-english', \
         tokenizer='distilbert-base-uncased-finetuned-sst-2-english')"

COPY app.py ${LAMBDA_TASK_ROOT}/

CMD ["app.handler"]

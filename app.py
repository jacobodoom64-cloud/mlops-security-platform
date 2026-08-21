import json

from transformers import pipeline

MODEL_NAME = "distilbert-base-uncased-finetuned-sst-2-english"

# Loaded once at container start, not per request.
# Lambda reuses a warm container across invocations, so this cost
# is paid on cold start only.
classifier = pipeline(
    "sentiment-analysis",
    model=MODEL_NAME,
    tokenizer=MODEL_NAME,
)


def handler(event, context):
    body = {}
    if event.get("body"):
        try:
            body = json.loads(event["body"])
        except json.JSONDecodeError:
            return _response(400, {"error": "Request body was not valid JSON"})

    text = body.get("text", "").strip()

    if not text:
        return _response(400, {"error": "Field 'text' is required and cannot be empty"})

    if len(text) > 2000:
        return _response(400, {"error": "Field 'text' exceeds the 2000 character limit"})

    try:
        result = classifier(text)[0]
    except Exception as exc:
        print(f"Inference failed: {type(exc).__name__}: {exc}")
        return _response(500, {"error": "Inference failed"})

    return _response(200, {
        "model": MODEL_NAME,
        "label": result["label"],
        "score": round(float(result["score"]), 4),
        "text": text,
    })


def _response(status, payload):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(payload),
    }

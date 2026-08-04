import json


def handler(event, context):
    """
    Placeholder inference handler.
    Returns a canned response so we can verify the deploy path
    before introducing a real model.
    """
    body = {}
    if event.get("body"):
        try:
            body = json.loads(event["body"])
        except json.JSONDecodeError:
            return {
                "statusCode": 400,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps({"error": "Request body was not valid JSON"}),
            }

    text = body.get("text", "")

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({
            "status": "ok",
            "message": "Placeholder handler - no model loaded yet",
            "received_text": text,
        }),
    }

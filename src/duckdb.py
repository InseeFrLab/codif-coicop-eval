import os
import duckdb


def create_connection():
    con = duckdb.connect(database=":memory:")
    con.execute(
        f"""
    CREATE SECRET secret_ls3 (
        TYPE S3,
        KEY_ID '{os.environ["AWS_ACCESS_KEY_ID"]}',
        SECRET '{os.environ["AWS_SECRET_ACCESS_KEY"]}',
        ENDPOINT '{os.environ["AWS_S3_ENDPOINT"]}',
        SESSION_TOKEN '{os.environ["AWS_SESSION_TOKEN"]}',
        REGION 'us-east-1',
        URL_STYLE 'path',
        SCOPE 's3://'
    );
    """
    )
    return con

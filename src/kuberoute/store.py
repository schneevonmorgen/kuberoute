import io
import tempfile

import boto3
import effect


class MutableStore(object):
    def __init__(self):
        self.records = None

    def _put(self, records):
        self.records = records

    def put(self, records):
        return effect.Effect(PutStore(self, records))

    def _get(self):
        return self.records

    def get(self):
        return effect.Effect(GetStore(self))


class S3BucketKey(object):
    def __init__(
            self,
            bucket_name,
            key,
            aws_access_key_id=None,
            aws_secret_access_key=None):
        self.con = boto3.client(
            's3',
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            region_name='eu-central-1',
        )
        self.bucket_name = bucket_name
        self.key = key

    def _write(self, content):
        with tempfile.TemporaryFile() as f:
            f.write(content.encode('utf-8'))
            f.seek(0)
            self.con.upload_fileobj(
                f, self.bucket_name, self.key, {'ACL':'public-read'}
            )

    def write(self, content):
        return effect.Effect(WriteS3Key(self, content))


class PutStore(object):
    def __init__(self, store, value):
        self.store = store
        self.value = value


@effect.sync_performer
def put_store_performer(dispatcher, intent):
    intent.store._put(intent.value)


class GetStore(object):
    def __init__(self, store):
        self.store = store


@effect.sync_performer
def get_store_performer(dispatcher, intent):
    return intent.store._get()


class WriteS3Key(object):
    def __init__(self, connection, content):
        self.connection = connection
        self.content = content


@effect.sync_performer
def write_s3_key_performer(dispatcher, intent):
    intent.connection._write(intent.content)


DISPATCHER = effect.TypeDispatcher({
    GetStore: get_store_performer,
    PutStore: put_store_performer,
    WriteS3Key: write_s3_key_performer,
})

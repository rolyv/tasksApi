import unittest
import json
import uuid
from lambda_functions import create
from unittest.mock import patch


class CreateTests(unittest.TestCase):
    # WIP - need to mock out boto3 setup
    def givenIncomingEvent_hanlderAssignsIdAndPutsItemInDynamo(self):
        event = {
            "user": "someUser@test.com",
            "description": "hello",
            "priority": 0
        }

        with patch.object(uuid, 'uuid4', return_value=uuid.UUID('a5bdce43-4e6c-4a6d-8712-5d6cef8389f8')) as mock_method:
            response = create.handler(event, None)

        assert json.loads(response["body"])["id"] == "a5bdce43-4e6c-4a6d-8712-5d6cef8389f8"


if __name__ == '__main__':
    unittest.main()

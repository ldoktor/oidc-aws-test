#!/bin/bash -x
aws logs create-log-group --log-group-name "/ldoktor/github-actions/oidc-test"
aws logs create-log-stream --log-group-name "/ldoktor/github-actions/oidc-test" --log-stream-name "oidc-aws-test"
# Test it
aws logs put-log-events --log-group-name "/ldoktor/github-actions/oidc-test" --log-stream-name "oidc-aws-test" --log-events "[{\"timestamp\":`date +%s%3N`, \"message\":\".\"}]"

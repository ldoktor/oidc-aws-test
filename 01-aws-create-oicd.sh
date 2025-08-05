# Step 1: Define variables (change as needed)
if [[ -z "$NAME" ]] || [[ -z "$AWS_ACCOUNT_ID" ]] || [[ -z "$GITHUB_ORG" ]] || [[ -z "$REPO_NAME" ]]; then
	echo "Please specify the ROLE_NAME AWS_ACCOUNT_ID GITHUB_ORG and REPO_NAME"
	exit 1
fi
#NAME="github-actions-oidc"
#AWS_ACCOUNT_ID="123456789012"  # Replace with your AWS account ID
#GITHUB_ORG="your-github-username"  # e.g., "octocat"
#REPO_NAME="my-test-repo"  # Your repo name

# Step 2: Create a trust policy for GitHub OIDC
# This allows GitHub Actions to assume this role
TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_ORG}/${REPO_NAME}:ref:refs/heads/main"
        },
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "https://token.actions.githubusercontent.com"
        }
      }
    }
  ]
}
EOF
)

# Step 3: Create the IAM role
aws iam create-role \
  --role-name "${NAME}-role" \
  --assume-role-policy-document "${TRUST_POLICY}" \
  --description "Role for GitHub Actions OIDC on ${REPO_NAME}"

# Step 4: Attach a minimal policy (only allows printing a message)
# This is the minimal permission needed for the example
POLICY_DOC=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "logs:PutLogEvents",
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
)

# Step 5: Create and attach the policy
aws iam create-policy \
  --policy-name "${NAME}-policy" \
  --policy-document "${POLICY_DOC}" \
  --description "Minimal policy for GH Actions OIDC example"

# Step 6: Attach the policy to the role
aws iam attach-role-policy \
  --role-name "${NAME}-role" \
  --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${NAME}-policy"

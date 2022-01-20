# Check `jq` dependency

if ! (command -v jq >/dev/null 2>&1); then
  echo "This command requires jq to be installed"
  exit 1
fi
T=$(eval echo "$TOKEN")
if [[ -n $CIRCLE_PULL_REQUEST ]]; then
  ## Get pull request number from URL
  PR_NUMBER=$(echo "$CIRCLE_PULL_REQUEST" | sed "s/.*\/pull\///")
  echo "PR_NUMBER: $PR_NUMBER"
  echo "export GITHUB_PR_NUMBER=$PR_NUMBER" >> "$BASH_ENV"

  ## Create GH API to get target branch
  API_GITHUB="https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME"
  echo "API_GITHUB: $API_GITHUB"
  PR_REQUEST_URL="$API_GITHUB/pulls/$PR_NUMBER"
  echo "PR_REQUEST_URL: $PR_REQUEST_URL"
  PR_RESPONSE=$(curl -H "Authorization: token ${T}" "$PR_REQUEST_URL")

  PR_TARGET_BRANCH=$(echo "$PR_RESPONSE" | jq -e '.base.ref' | tr -d '"')
  echo "PR_TARGET_BRANCH: $PR_TARGET_BRANCH"
  echo "export GITHUB_PR_TARGET_BRANCH='${PR_TARGET_BRANCH/"'"/}'" >> "$BASH_ENV"
else
  echo "There is no pull request associated with this commit"
fi
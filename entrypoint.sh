#!/bin/sh -l

# Configure Theme Kit.
theme configure --store=$INPUT_STORE --password=$INPUT_PASSWORD  --themeid=$INPUT_THEME_ID --dir=$INPUT_PATH

# Fetch the deploy hash from the theme, if it exists and ignoring a file not found error.
theme download assets/wC8_deploy_sh.txt || true
LAST_wC8_deploy_sh=$(cat "$INPUT_PATH/assets/wC8_deploy_sh.txt")

echo "---> LAST_wC8_deploy_sh is $LAST_wC8_deploy_sh"

# Check if we could retrieve a deploy SHA.
if [ ! -z "$LAST_wC8_deploy_sh" ]; then
  # Get a list of files that have changed in our Shopify theme since the last deploy.
  CHANGED_FILES=$(git diff "$LAST_wC8_deploy_sh..$GITHUB_SHA" --name-only -- $INPUT_PATH/assets $INPUT_PATH/config $INPUT_PATH/layout $INPUT_PATH/locales $INPUT_PATH/sections $INPUT_PATH/snippets $INPUT_PATH/templates)

  if [ ! -z "$CHANGED_FILES" ]; then
    CHANGED_FILES_RELATIVE=$(echo "$CHANGED_FILES" | xargs realpath --relative-to=$INPUT_PATH)

    echo "---> CHANGED_FILES_RELATIVE is $CHANGED_FILES_RELATIVE"

    # Deploy only those changes, if they exist.
    if [ ! -z "$CHANGED_FILES_RELATIVE" ]; then
      echo "$CHANGED_FILES_RELATIVE" | xargs theme deploy $INPUT_ADDITIONAL_ARGS
    fi
  fi
else
  # Deploy all files.
  theme deploy $INPUT_ADDITIONAL_ARGS
fi

# Upload the latest deploy SHA.
echo $GITHUB_SHA > "$INPUT_PATH/assets/wC8_deploy_sh.txt"
theme deploy assets/wC8_deploy_sh.txt
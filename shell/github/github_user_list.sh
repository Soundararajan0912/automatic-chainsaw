
#!/bin/bash

# Script to list teams, team members, and direct collaborators for each repo, and save to CSV
GITHUB_TOKEN=""
ORG_NAME=""
REPOS=(
  ""
  ""
)

OUTPUT_FILE="github_access_report.csv"
echo "Repository,Team/User,Type,Permission" > "$OUTPUT_FILE"

for REPO in "${REPOS[@]}"; do
  # Get teams with access to the repo
  TEAMS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$ORG_NAME/$REPO/teams" | jq -c '.[]')
  if [ -n "$TEAMS" ]; then
    echo "$TEAMS" | while read -r TEAM; do
      TEAM_NAME=$(echo "$TEAM" | jq -r '.name')
      PERMISSION=$(echo "$TEAM" | jq -r '.permission')
      TEAM_SLUG=$(echo "$TEAM" | jq -r '.slug')
      # List team itself
      echo "$REPO,$TEAM_NAME,Team,$PERMISSION" >> "$OUTPUT_FILE"
      # Get members of the team
      MEMBERS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/orgs/$ORG_NAME/teams/$TEAM_SLUG/members" | jq -r '.[].login')
      if [ -n "$MEMBERS" ]; then
        for MEMBER in $MEMBERS; do
          echo "$REPO,$MEMBER,Team Member,$PERMISSION" >> "$OUTPUT_FILE"
        done
      fi
    done
  fi

  # Get direct collaborators (users added directly to repo)
  COLLABS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$ORG_NAME/$REPO/collaborators?affiliation=direct" | jq -c '.[]')
  if [ -n "$COLLABS" ]; then
    echo "$COLLABS" | while read -r COLLAB; do
      USERNAME=$(echo "$COLLAB" | jq -r '.login')
      PERMISSION=$(echo "$COLLAB" | jq -r '.permissions | to_entries | map(select(.value==true)) | .[0].key')
      echo "$REPO,$USERNAME,Direct Collaborator,$PERMISSION" >> "$OUTPUT_FILE"
    done
  fi
done

echo "Report saved to $OUTPUT_FILE"
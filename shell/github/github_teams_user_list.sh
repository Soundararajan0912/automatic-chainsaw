#!/bin/bash

# Script to list all teams in the org and their users, save to CSV
GITHUB_TOKEN=" "
ORG_NAME=" "
OUTPUT_FILE="github_org_teams_users.csv"
echo "Team,User" > "$OUTPUT_FILE"

# Get all teams in the org
TEAMS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
	"https://api.github.com/orgs/$ORG_NAME/teams?per_page=100" | jq -c '.[]')

if [ -n "$TEAMS" ]; then
	echo "$TEAMS" | while read -r TEAM; do
		TEAM_NAME=$(echo "$TEAM" | jq -r '.name')
		TEAM_SLUG=$(echo "$TEAM" | jq -r '.slug')
		# Get members of the team
		MEMBERS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
			"https://api.github.com/orgs/$ORG_NAME/teams/$TEAM_SLUG/members?per_page=100" | jq -r '.[].login')
		if [ -n "$MEMBERS" ]; then
			for MEMBER in $MEMBERS; do
				echo "$TEAM_NAME,$MEMBER" >> "$OUTPUT_FILE"
			done
		else
			echo "$TEAM_NAME," >> "$OUTPUT_FILE"
		fi
	done
fi

echo "Report saved to $OUTPUT_FILE"

#!/usr/bin/env python3
import argparse

from github import Auth
from github import Github

parser = argparse.ArgumentParser(prog='OrganizationRepositoriesReport',
                                 description='Make organization repositories report')
parser.add_argument('-o',
                    '--organization',
                    help='Github Organization Name',
                    type=str)
parser.add_argument('-t',
                    '--token',
                    help='Github Action Token',
                    type=str)
args = parser.parse_args()

### Main Login
auth = Auth.Token(args.token) if args.token else None
client = Github(auth=auth)
organization = client.get_organization(args.organization)
repositories = organization.get_repos()
repositories = sorted(repositories, key=lambda repository: repository.name.lower())
content = """"""
for repo in repositories:
    content += f"# {repo.name}  \n"
    content += f"**Name**: {repo.name}  \n"
    content += f"**URL**: {repo.url}  \n"
print(content)

with open('/output/report.md', 'w') as file:
    file.write(content)

import shutil

shutil.copytree("/output", "/github/workspace/output")

# Setup 

1. Create a slack app
2. Create a webhook integrated with some slack channel
3. Create a github secret named `SLACK_WEBHOOK` and set the value what ever is after `services/` in the webhook

# Usage

```yaml
slack-alert:
name: Slack alert
needs: [some-build-action]
runs-on: ubuntu-22.04
env:
    AUTHOR: ${{ github.actor }}
    EVENT: ${{ github.event_name }}
    IMAGE: ${{ github.ref_name }}
    SLACK_WEBHOOK: '${{ secrets.SLACK_WEBHOOK }}' 
    AH_DEVELOPERS: '${{ secrets.DEVELOPERS }}'
steps:
    - uses: actions/checkout@v3

    - uses: actions/setup-python@v4
    with:
        python-version: '3.8.13'
        cache: pip

    - name: Install dependencies
    run: pip install -r tools/slack_alert/requirements.txt

    - name: Run script
    run: |
        export TAG=$(git rev-parse --short HEAD)
        python tools/slack_alert/slack_alert.py
```

### TODO: add more dynamic functions

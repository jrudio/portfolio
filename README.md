# About

I intend to create a ~~beautifully~~ designed website that will be my portfolio

# Requirements

- ~~Use Go for the backend~~
- ~~Use a JavaScript framework specifically for static pages on the frontend~~
- Do not use a database -- this will be strictly static!
- ~~Output to a single binary -- pack the static assets into the binary as well~~

# Deployment

For a static website such as this it should be hosted on a free tier service such as github pages. I think I am going to go with a small VM (f1-micro) on Google Cloud, just because.

I plan on creating a startup script for the VM to provision the server for required tools.

- Caddy (for serving static files, https goodness, logs, etc)
- Utilize Github Actions for CI/CD

To execute terraform code:

```
GCLOUD_PROJECT=<project-id> GOOGLE_CREDENTIALS=<path-to-service-account-json> terraform apply
```

Service account must have the following IAM permissions:

- Compute Admin (create VM)
- Service Account Admin (creates a service account)
- Service Account User (uses created service account on VM)
- Storage Admin (create bucket)

For restarts:

- Make sure we run caddy with the proper arguments and Caddyfile

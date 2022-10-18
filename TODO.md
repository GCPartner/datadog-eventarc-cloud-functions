# TODO
## Cody
1. ~~Create secrets on the fly for secret manager~~
    * ~~Enable the API~~
    * ~~Create Secrets~~
2. Create Cloud Function on the fly
    * Enable the API
    * Create Service Account to access Secrets
      * roles/secretmanager.secretAccessor
    * Upload the function
    * Create the trigger as EventArc??
3. Create EventArc integration on the fly
    * Enable the API
    * Create the "Topic" for DataDog
    * Create the Trigger for Cloud Functions
4. Create Datadog Alert on the fly
    * Create the Alert (Hopefully they have Terraform)
    * Create a trigger for the alert to point to EventArc
## Usman
1. ~~Create a user to showcase the console~~
2. ~~Get DNS Setup to use a different domain~~
3. Research what's possible to do with Datadog and Terraform:
    * We want to create alerts and triggers on the fly if possible
        * Create alert based on k8s
        * Set threshold for alert
        * EventArc Channel Creation thing...
        * Create trigger for EventArc...

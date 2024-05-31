public class RandomUserAPI {

    public static void createRandomContact() {

        // Create a new HTTP request
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://randomuser.me/api/');
        request.setMethod('GET');
        
        // Execute the request
        HttpResponse response = http.send(request);

        Logger.debug('Random User API Response', response.getBody());
        
        // Check if the request was successful
        if (response.getStatusCode() == 200) {
            // Parse the JSON response
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            List<Object> results = (List<Object>) responseMap.get('results');
            if (results.size() > 0) {
                Map<String, Object> userData = (Map<String, Object>) results[0];
                
                // Extract user data
                Map<String, Object> name = (Map<String, Object>) userData.get('name');
                String firstName = (String) name.get('first');
                String lastName = (String) name.get('last');
                
                Map<String, Object> location = (Map<String, Object>) userData.get('location');
                String city = (String) location.get('city');
                String state = (String) location.get('state');
                
                String email = (String) userData.get('email');
                
                // Create a new Contact object
                Contact newContact = new Contact(
                    FirstName = firstName,
                    LastName = lastName,
                    MailingCity = city,
                    MailingState = state,
                    Email = email
                );
                
                // Save the contact in Salesforce
                try {
                    insert newContact;
                } catch (Exception e) {
                    Logger.handle(e);
                }

            }
        } else {
            // Log an error if the request was not successful
            System.debug('Error in request: ' + response.getStatus());
        }
    }
}

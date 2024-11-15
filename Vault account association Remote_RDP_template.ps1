# Define the API credentials
$tokenUrl = "https://[yourURL]/oauth2/token"
$baseUrl = "https://[yourURL]/api/config/v1" #note the backup api URL is different to config API URL
$client_id = "--"   # Replace with your actual client ID
$secret = "--"         # Replace with your actual secret

#endregion creds
###########################################################################

#region Authent 
###########################################################################

# Step 1. Create a client_id:secret pair
$credPair = "$($client_id):$($secret)"
# Step 2. Encode the pair to Base64 string
$encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credPair))
# Step 3. Form the header and add the Authorization attribute to it
$headersCred = @{ Authorization = "Basic $encodedCredentials" }
# Step 4. Make the request and get the token
$responsetoken = Invoke-RestMethod -Uri "$tokenUrl" -Method Post -Body "grant_type=client_credentials" -Headers $headersCred
$token = $responsetoken.access_token
$headersToken = @{ Authorization = "Bearer $token" }
# Step 5. Prepare the header for future request
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Accept", "application/json")
$headers.Add("Authorization", "Bearer $token")
#endregion
###########################################################################

## Accounts

# Construct the full URL for vault account listing
$vaultaccountlisturl = "$baseUrl/vault/account"

# Invoke the REST method to list vault accounts
$vaultaccountlist = Invoke-RestMethod -Uri $vaultaccountlisturl -Method GET -Headers $headers

# Print only the 'name' and 'id' for each account
$vaultaccountlist | ForEach-Object {
    Write-Output "Account Name: $($_.name), ID: $($_.id)"
}


## Jump Items

# Construct the full URL for jump item listing
$jumpitemlisturl = "$baseUrl/jump-item/remote-rdp"

# Invoke the REST method to list jump items
$jumpitemlist = Invoke-RestMethod -Uri $jumpitemlisturl -Method GET -Headers $headers

# Print only the 'name' and 'id' for each jump item
$jumpitemlist | ForEach-Object {
    Write-Output "Jump-Item Name: $($_.name), ID: $($_.id)"
}


# Compare names and perform the association action where there is a match
foreach ($vaultaccount in $vaultaccountlist) {
    foreach ($jumpitem in $jumpitemlist) {
        # Compare the names of the vault account and jump item (case-insensitive)
        if ($vaultaccount.name -ieq $jumpitem.name) {
            # Set the vault account ID and jump item ID for the API call
            $vaultaccountid = $vaultaccount.id
            $jumpitemid = $jumpitem.id

            # Construct the URL for associating the jump item with the vault account
            $linkingurl = "$baseUrl/vault/account/$vaultaccountid/jump-item-association"

            # Define the body in the expected format
            $body = @{
                filter_type = "criteria"  # Matches the output format's filter_type
                criteria    = ""          # Set criteria as needed; an empty string is shown in your example
                jump_items  = @(
                    @{
                        id   = $jumpitemid
                        type = "remote_rdp"  # Modify this as needed; options could include jump_client, remote_rdp, etc.
                    }
                )
            } | ConvertTo-Json -Compress

            # Perform the POST request with the constructed body
            try {
                $response = Invoke-RestMethod -Uri $linkingurl -Method POST -Headers $headers -Body $body
                Write-Output "Successfully associated Vault Account '$($vaultaccount.name)' with Jump Item '$($jumpitem.name)'"
            }
            catch {
                Write-Output "Failed to associate Vault Account '$($vaultaccount.name)' with Jump Item '$($jumpitem.name)' If error 422 is returned the vault account may already have a configured association: $_"
            }
        }
    }
}

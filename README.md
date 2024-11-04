# PRA_Account_Association
Links vault accounts and Remote RDP jump items of the same name.

Will fail if the account has been configured to have any associations already, this only works for Remote RDP Jump Items, but could be modified to do Shell Jumps etc.

Useful when domain accounts are used on a 1:1 basis

Example output below, the first account had a pre-existing association so writing one to it failed.

  Failed to associate Vault Account 'testcompare1' with Jump Item 'testcompare1'
  If error 422 is returned the vault account may already have a configured association: The remote server returned an error: (422) Unprocessable Content.
  
  Successfully associated Vault Account 'testcompare2' with Jump Item 'testcompare2'

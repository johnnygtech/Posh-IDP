# Posh-IDP
An Identity Provider / Token Issuer written leveraging the Polaris Project, my personal implementations of JWT and RFC2898 Password hashing

#Get Started
1. Clone this project
2. Clone Polaris (probably should grab from my repo as it is very much under development)
3. Clone Posh-JWT and Posh-PWD from my repositories
 
*Note: You must configure a shared key in the config.json file for the JWT implementation
4. run ./start.ps1
5. Create a user by posting this schema 
  {
    "username": "",
    "lName": "",
    "fName": "",
    "email": "",
    "password": ""
  }
  to /v1/user
6. Test user with a get to /v1/user?username=<username>
7. Login / Generate Token with post to /v1/login with the following schema
  {
    "username": "",
    "password": ""
  }

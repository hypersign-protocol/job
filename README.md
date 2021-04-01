# This is what you have to do

You need to create a WebApp connected with a node js server which exposes an api to store an data with respect to user. You do not need database connections, can use in-memory store. See the architecture. 

![image](https://user-images.githubusercontent.com/15328561/113234757-81dbb300-92bf-11eb-9dd8-edb68d3a01c9.png)


## Section 1: FrontEnd

Frontend must be based on some framework. You can use React or Vue or whatever framework of your choice.

### Part 1; Implement a basic form page

- Create a page where you have a form. The form should contain the following fields. `userDID`, `ethAddress`, `facebookId`, `twitterHandle`. 
- Once user click on the `Submit` button, it you call an API `/save` to store this information. (you will create the API in the next section)

### Part 2: Implement Hypersign auth

- You need to design a login page for this app. (No need for registration)
- The login page should have a QR code and user will use [Hypersign Identity Wallet (mobile app)](https://play.google.com/store/apps/details?id=com.hypersign.cordova) to login into your webapp. [Here](https://hsdev.netlify.app/studio/login) is how an example website with passwordless login looks like (I encourage you to try to login into this site and see the user expereice, before proceeding)
- Once user logged in, he can fill the above form described in Part 1 of the problem. 
- If user has already doen the submittion, he should see his detail. 

## Section 2: Middleware

### Part 1; Implement two basic APIs

This is nodejs based express server which exposes one POST API called `/save` and one get API `/fetch`. When you hit `/save` API by passing JSON object in the request body, it should be able to store the object in a Map.

The object should look like this:

```
{
  "userDID": "xxxxxxxx",
  "ethAddress": "xxxxxxxxxxxxxx",
  "facebookId": "rrrrrrr",
  "twitterHandle": "abdc"
}
```

The key of Map should be `userDID`;

When you call `/fetch` api, it should return list of all objects. 

### Part 2: Implement Hypersign auth

- Once this is done, you need to implement authentication to protect your GET and POST apis from unauthorized access. 
- For that you need to use Hypersign Passwordless authentication. Follow [implementation documenation](https://vishwas-anand-bhushan.gitbook.io/hypersign/developer/sdk/dev-nodejs) to implement Hypersign auth in your project.

## How can I submit the code?

1. Clone this repo in your local system
2. Create a branch in this format: `<your first name>_<your last name>`
3. Start coding. Your root dir should have two folders, `frontend` and `middleware` for UI and APIs respectively.
4. Push your code.
5. Give me a PR to review.

## How can I stand out of the crowd?

- Using typescirpt
- Using proper project struture and following basic coding standard for APIs
- If you can show me live demo (like by deploying in AWS or Heroku or Netlify etc), I will be impress for sure!

## Timeline

1 week

## What we want to judge?

- We want to know if you have basic knowledge of end-to-end developement or not?
- End to end includes, basic UI, basic APIs, concept of GIT, basic research.
- We want to know if you have given a new thing to study, how much egar you are to learn and try things out?

## Lastly

> You must know that we really want to hire you. If you need any help or get stucked anywhere,  immediately reach out to us. 




import {
    CognitoUserPool,
    CognitoUser,
    AuthenticationDetails,
    CognitoUserAttribute
  } from "amazon-cognito-identity-js";

  // Generated output file from Terraform's AWS Cognito module
  import cognitoConfigJson from "../../certs/cognito-config.json";

  export const cognitoConfig = {
    region: cognitoConfigJson.region,
    userPoolId: cognitoConfigJson.userPoolId,
    clientId: cognitoConfigJson.userPoolClientId,
  };
  
  const userPool = new CognitoUserPool({
    UserPoolId: cognitoConfig.userPoolId,
    ClientId: cognitoConfig.clientId,
  });
  
  export const login = async (
    username: string,
    password: string,
    newPassword?: string
  ): Promise<string> => {
    return new Promise((resolve, reject) => {
      const cognitoUser = new CognitoUser({
        Username: username,
        Pool: userPool,
      });
  
      const authenticationDetails = new AuthenticationDetails({
        Username: username,
        Password: password,
      });
  
      cognitoUser.authenticateUser(authenticationDetails, {
        onSuccess: (result) => {
          const idToken = result.getIdToken().getJwtToken();
          resolve(idToken);
        },
        onFailure: (err) => {
          reject(err);
        },
        newPasswordRequired: (userAttributes, requiredAttributes) => {
          if (!newPassword) {
            return reject(
              new Error("New password is required, but no new password was provided.")
            );
          }
  
          // Remove attributes Cognito doesn't accept when submitting new password
          delete userAttributes.email;
          delete userAttributes.email_verified;
  
          cognitoUser.completeNewPasswordChallenge(newPassword, userAttributes, {
            onSuccess: (result) => {
              const idToken = result.getIdToken().getJwtToken();
              resolve(idToken);
            },
            onFailure: (err) => {
              reject(err);
            },
          });
        },
      });
    });
  };

  // Logout Function
export const logout = (): Promise<void> => {
    return new Promise((resolve, reject) => {
      const cognitoUser = userPool.getCurrentUser();
  
      if (!cognitoUser) {
        return reject(new Error("No user is currently signed in."));
      }
  
      cognitoUser.signOut(); // Local logout (clears session in browser)
      resolve();
    });
  };
  
// Global Logout (Optional)
export const globalLogout = (): Promise<void> => {
  return new Promise((resolve, reject) => {
    const cognitoUser = userPool.getCurrentUser();

    if (!cognitoUser) {
      return reject(new Error("No user is currently signed in."));
    }

    cognitoUser.globalSignOut({
      onSuccess: () => {
        resolve();
      },
      onFailure: (err) => {
        reject(err);
      },
    });
  });
};

export const signUp = (username: string, email: string, password: string): Promise<void> => {
  return new Promise((resolve, reject) => {
    const attributes = [
      new CognitoUserAttribute({ Name: "email", Value: email }),
    ];

    userPool.signUp(username, password, attributes, [], (err, result) => {
      if (err) {
        return reject(err);
      }
      resolve();
    });
  });
};

export const confirmSignUp = (username: string, code: string): Promise<void> => {
  return new Promise((resolve, reject) => {
    const cognitoUser = new CognitoUser({
      Username: username,
      Pool: userPool,
    });

    cognitoUser.confirmRegistration(code, true, (err, result) => {
      if (err) {
        return reject(err);
      }
      console.log("Confirmation result:", result);
      resolve();
    });
  });
};

// export default defineNuxtRouteMiddleware((to) => {
//     const isLoggedIn = useCookie("authToken").value;
//     const publicPages = ["/login", "/signup", "/about"];
  
//     // If not logged in and not on a public page, redirect to login
//     if (!isLoggedIn && !publicPages.includes(to.path)) {
//       return navigateTo("/login");
//     }
  
//     // Allow navigation
//     return true;
//   });

export default defineNuxtRouteMiddleware((to) => {
  const isLoggedIn = useCookie('authToken').value; // Check the auth token in cookies
  const publicPages = ['/login', '/signup']; // Define routes that don't require authentication

  if (!isLoggedIn && !publicPages.includes(to.path)) {
    return navigateTo('/login'); // Redirect to login if not authenticated
  }
});
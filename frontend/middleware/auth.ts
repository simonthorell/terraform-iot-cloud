export default defineNuxtRouteMiddleware((to) => {
  // Check the auth token in cookies
  const isLoggedIn = useCookie('authToken').value; 

  // Define routes that don't require authentication
  const publicPages = ['/login', '/signup']; 

  if (!isLoggedIn && !publicPages.includes(to.path)) {
    return navigateTo('/login'); // Redirect to login if not authenticated
  }
});
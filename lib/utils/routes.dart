class Routes {
  // Authentication
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';

  // Movies
  static const movieFeed = '/movies';
  static const addMovie = '/movies/add';
  static const movieDetail = '/movieDetail';
  static const adminMovies = '/movies/admin';
  static const seatReservation = '/seatReservation';

  // Clubs
  static const viewClubs = '/clubs'; // View all clubs
  static const adminClubs = '/clubs/admin'; // Admin manage clubs
  static const addClub = '/clubs/add'; // Admin add new club
  static const clubFeed = '/clubs/feed'; // Public club news/events feed

  // Events
  static const eventFeed = '/events/feed'; // Public events feed
  static const adminEvents = '/events/admin'; // Admin manage events
  static const addEvent = '/admin/event/add'; // Admin add new event
  static const editEvent = '/admin/event/edit'; // Admin edit event
  static const resetPassword = '/reset-password'; // Reset password screen
  static const reservation = '/reservation'; // Seat reservation screen

  static const chatBot = '/chatbot'; // Chatbot assistant screen
  static const verification = '/verification'; // Email verification screen
  static const adminReservations = '/admin/reservations'; // Admin manage reservations
  static const analytics = '/analytics'; // Analytics and stats screen
}

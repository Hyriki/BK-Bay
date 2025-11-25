
import { Route, Routes } from 'react-router-dom';
import ProtectedRoute from './components/ProtectedRoute';
import PublicRoute from './components/PublicRoute';
import ShoppingCart from './pages/CartPage';
import ShipperDetails from './pages/Shipper/ShipperDetails';
import SellerProductReport from './pages/Seller/SellerProductReport';
import LandingPage from './pages/Home/LandingPage';
import Promotion from './pages/promotion/Promotion';
import UserDetails from './pages/User/UserDetails';
<<<<<<< HEAD
import ProductReviews from './pages/Review/ProductReviews';
=======
import LoginPage from './pages/Login/loginPage';
>>>>>>> 8fcba1c7de55b1642ef28cbe39c1b01b60c96a3a

function App() {
  return (
    <Routes>
<<<<<<< HEAD
      <Route path="/" element={<HomePage/>} />
      <Route path="/about" element={<h1>About Page</h1>} />
      <Route path="/cart" element={<ShoppingCart/>} />
      <Route path="/shipper-details" element={<ShipperDetails />} />
      <Route path="/seller-report" element={<SellerProductReport />} />
      <Route path="/promotion" element={<Promotion />} />
      <Route path="/user" element={<UserDetails />} />
      <Route path="/review" element={<ProductReviews />} />
=======
      <Route path="/login" element={
        <PublicRoute>
          <LoginPage />
        </PublicRoute>} />

      {/* Protected Routes */}
      <Route path="/" element={
        <ProtectedRoute>
          <LandingPage />
        </ProtectedRoute>} />
      <Route path="/cart" element={
        <ProtectedRoute>
          <ShoppingCart />
        </ProtectedRoute>
      } />
      <Route path="/shipper-details" element={
        <ProtectedRoute>
          <ShipperDetails />
        </ProtectedRoute>
      } />
      <Route path="/seller-report" element={
        <ProtectedRoute>
          <SellerProductReport />
        </ProtectedRoute>
      } />
      <Route path="/promotion" element={
        <ProtectedRoute>
          <Promotion />
        </ProtectedRoute>
      } />
      <Route path="/user" element={
        <ProtectedRoute>
          <UserDetails />
        </ProtectedRoute>
      } />
>>>>>>> 8fcba1c7de55b1642ef28cbe39c1b01b60c96a3a
    </Routes>
  );
}

export default App

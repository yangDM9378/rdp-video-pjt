import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import RdpPage from "./pages/RdpPage";

export default function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<div>메인 페이지</div>} />
        <Route path="/rdp" element={<RdpPage />} />
      </Routes>
    </Router>
  );
}
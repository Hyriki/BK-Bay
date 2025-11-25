// File: D:/Ecommerce/src/pages/Home/HomePage.jsx

import React from 'react';
import Header from '../../components/header/Header';
import Footer from '../../components/footer/Footer';
import { useNavigate } from 'react-router-dom';

// Import your image correctly (adjust path if needed)
// logo image removed — using text logo/button instead

export default function LandingPage() {
    const navigate = useNavigate();

    return (
        <div className="min-h-screen bg-white font-sans text-gray-800">
            <Header />

            <main>
                {/* Hero Section */}
                <section
                    className="relative text-white py-20 md:py-32 overflow-hidden"
                    style={{ background: 'linear-gradient(to right, var(--color-primary), var(--color-border-primary))' }}
                >
                    {/* Overlay for readability (inline rgba to avoid reliance on arbitrary opacity utilities) */}
                    <div className="absolute inset-0" style={{ backgroundColor: 'rgba(0,0,0,0.45)' }}></div>

                    {/* Content */}
                    <div className="relative z-10 max-w-7xl mx-auto px-6 flex flex-col md:flex-row items-center justify-between gap-10">
                        <div className="md:w-1/2 text-center md:text-left">
                            <h1 className="text-4xl md:text-6xl font-extrabold leading-tight mb-4">
                                Buy it, sell it, love it
                            </h1>
                            <p className="text-lg md:text-xl mb-8 opacity-90">
                                Whatever it is, you can get it on BKBay
                            </p>
                            {/* Simplified hero: no extra buttons */}
                            <div className="mt-6 max-w-2xl mx-auto md:mx-0">
                                <p className="text-base md:text-lg text-gray-100/90">Welcome to BKBay — your marketplace for everything.</p>
                            </div>
                        </div>

                        {/* Text logo button (click to go to homepage) */}
                        <div className="md:w-1/2 flex justify-center md:justify-end mt-10 md:mt-0">
                            <button
                                onClick={() => navigate('/home')}
                                className="cursor-pointer text-white text-3xl md:text-4xl font-extrabold px-6 py-4 rounded-md bg-transparent transform transition-transform duration-200 shadow-sm hover:-translate-y-1 hover:shadow-2xl"
                                aria-label="Go to homepage"
                            >
                                BK BAY
                            </button>
                        </div>
                    </div>
                </section>

                {/* Signup CTA removed as requested */}
            </main>

            <Footer />
        </div>
    );
}
const API_URL = '/api/users'; 

const safeJsonParse = async (response) => {
    try {
        
        return await response.json();
    } catch (e) {
        
        return {}; 
    }
};

export async function registerUser(userData) {
    try {
        const response = await fetch(`${API_URL}/register`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(userData),
        });

        const data = await safeJsonParse(response); 

        if (!response.ok) {
            
            throw new Error(data.error || data.message || `API Failure: Status ${response.status}`);
        }

        return data; 
    } catch (error) {
        console.error('Registration failed in service:', error.message);
        throw error;
    }
}

export async function loginUser(credentials) {
    const response = await fetch("http://localhost:5173/api/users/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(credentials)
    });

    if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        const err = new Error("Login failed");
        err.status = response.status;
        err.data = errorData;
        throw err;
    }

    return response.json();
}
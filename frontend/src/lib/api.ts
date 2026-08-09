import axios from 'axios';

const backendBaseUrl =
  import.meta.env.VITE_BACKEND_BASE_URL ?? 'http://localhost:8080';

export const backendApi = axios.create({
  baseURL: backendBaseUrl,
  timeout: 5000,
});

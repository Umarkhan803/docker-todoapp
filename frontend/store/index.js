import { create } from "zustand";
import axios from "axios";
import toast from "react-hot-toast";

const API_BASE = import.meta.env.VITE_API_URL || "/api";

const useStore = create((set, get) => ({
  todos: [],
  isLoading: false,

  createTodo: async (title) => {
    set({ isLoading: true });
    try {
      const res = await axios.post(`${API_BASE}/todos`, { title });
      if (res.status === 201) {
        await get().getAllTodos();
        toast.success("Todo created successfully");
      }
    } catch (err) {
      toast.error(err.response?.data?.message || "Failed to create todo");
    } finally {
      set({ isLoading: false });
    }
  },

  getAllTodos: async () => {
    set({ isLoading: true });
    try {
      const res = await axios.get(`${API_BASE}/todos`);
      if (res.status === 200) {
        set({ todos: res.data ?? [] });
      }
    } catch (err) {
      toast.error(err.response?.data?.message || "Failed to load todos");
    } finally {
      set({ isLoading: false });
    }
  },

  deleteTodo: async (id) => {
    set({ isLoading: true });
    try {
      const res = await axios.delete(`${API_BASE}/todos/${id}`);
      if (res.status === 200) {
        await get().getAllTodos();
        toast.success("Todo deleted successfully");
      }
    } catch (err) {
      toast.error(err.response?.data?.message || "Failed to delete todo");
      set({ isLoading: false });
    }
  },

  updateTodo: async (id, title) => {
    set({ isLoading: true });
    try {
      await axios.put(`${API_BASE}/todos/${id}`, { title });
      await get().getAllTodos();
      toast.success("Todo updated successfully");
    } catch (err) {
      toast.error(err.response?.data?.message || "Failed to update todo");
    } finally {
      set({ isLoading: false });
    }
  },
}));

export default useStore;
// This store manages the state of the todo list.

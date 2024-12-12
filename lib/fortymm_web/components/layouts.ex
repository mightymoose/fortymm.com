defmodule FortymmWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use FortymmWeb, :controller` and
  `use FortymmWeb, :live_view`.
  """
  use FortymmWeb, :html

  embed_templates "layouts/*"

  def profile_dropdown(%{current_user: nil} = assigns) do
    ~H"""
    <div class="text-sm font-medium text-white space-x-3">
      <.link href={~p"/users/register"} aria-current="page">
        Sign up
      </.link>
      <.link href={~p"/users/log_in"}>
        Log in
      </.link>
    </div>
    """
  end

  def profile_dropdown(assigns) do
    ~H"""
    <div class="relative ml-3 hidden md:block" x-data="{ profileDropdownIsOpen: false }">
      <div>
        <button
          type="button"
          class="relative flex max-w-xs items-center rounded-full bg-gray-800 text-sm text-white focus:outline-none focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-gray-800"
          id="user-menu-button"
          aria-expanded="false"
          aria-haspopup="true"
          @click="profileDropdownIsOpen = !profileDropdownIsOpen"
        >
          <span class="absolute -inset-1.5"></span>
          <span class="sr-only">Open user menu</span>
          <span class="inline-block size-8 overflow-hidden rounded-full bg-gray-100">
            <svg class="size-full text-gray-300" fill="currentColor" viewBox="0 0 24 24">
              <path d="M24 20.993V24H0v-2.996A14.977 14.977 0 0112.004 15c4.904 0 9.26 2.354 11.996 5.993zM16.002 8.999a4 4 0 11-8 0 4 4 0 018 0z" />
            </svg>
          </span>
        </button>
        <div
          x-cloak
          x-transition:enter="transition ease-out duration-100"
          x-transition:enter-start="transform opacity-0 scale-95"
          x-transition:enter-end="transform opacity-100 scale-100"
          x-transition:leave="transition ease-in duration-75"
          x-transition:leave-start="transform opacity-100 scale-100"
          x-transition:leave-end="transform opacity-0 scale-95"
          x-show="profileDropdownIsOpen"
          @click.away="profileDropdownIsOpen = false"
          class="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black/5 focus:outline-none"
          role="menu"
          aria-orientation="vertical"
          aria-labelledby="user-menu-button"
          tabindex="-1"
        >
          <!-- Active: "bg-gray-100 outline-none", Not Active: "" -->
          <.link href={~p"/users/settings"} class="block px-4 py-2 text-sm text-gray-700">
            Settings
          </.link>
          <.link
            href={~p"/users/log_out"}
            method="delete"
            class="block px-4 py-2 text-sm text-gray-700"
            role="menuitem"
            tabindex="-1"
            id="user-menu-item-2"
          >
            Log out
          </.link>
        </div>
      </div>
    </div>
    """
  end

  def mobile_menu(assigns) do
    ~H"""
    <div class="space-y-1 px-2 pb-3 pt-2 sm:px-3">
      <!-- Current: "bg-gray-900 text-white", Default: "text-gray-300 hover:bg-gray-700 hover:text-white" -->
      <.link
        href={~p"/dashboard"}
        class="block rounded-md bg-gray-900 px-3 py-2 text-base font-medium text-white"
        aria-current="page"
      >
        Dashboard
      </.link>
    </div>
    <div class="border-t border-gray-700 pb-3 pt-4">
      <div class="flex items-center px-5">
        <div class="shrink-0">
          <span class="inline-block size-10 overflow-hidden rounded-full bg-gray-100">
            <svg class="size-full text-gray-300" fill="currentColor" viewBox="0 0 24 24">
              <path d="M24 20.993V24H0v-2.996A14.977 14.977 0 0112.004 15c4.904 0 9.26 2.354 11.996 5.993zM16.002 8.999a4 4 0 11-8 0 4 4 0 018 0z" />
            </svg>
          </span>
        </div>
        <div class="ml-3">
          <div class="text-base font-medium text-white">{@current_user.username}</div>
          <div class="text-sm font-medium text-gray-400">{@current_user.email}</div>
        </div>
      </div>
      <div class="mt-3 space-y-1 px-2">
        <.link
          href={~p"/users/settings"}
          class="block rounded-md px-3 py-2 text-base font-medium text-gray-400 hover:bg-gray-700 hover:text-white"
        >
          Settings
        </.link>
        <.link
          href={~p"/users/log_out"}
          method="delete"
          class="block rounded-md px-3 py-2 text-base font-medium text-gray-400 hover:bg-gray-700 hover:text-white"
        >
          Sign out
        </.link>
      </div>
    </div>
    """
  end
end

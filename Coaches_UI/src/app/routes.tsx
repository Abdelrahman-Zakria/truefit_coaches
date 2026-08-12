import { createBrowserRouter } from "react-router";
import Login from "./screens/Login";
import Root from "./screens/Root";
import Home from "./screens/Home";
import Schedule from "./screens/Schedule";
import Members from "./screens/Members";
import MemberProfile from "./screens/MemberProfile";
import PTRequests from "./screens/PTRequests";
import Chat from "./screens/Chat";
import TimeTracking from "./screens/TimeTracking";
import Attendance from "./screens/Attendance";
import Notifications from "./screens/Notifications";
import Management from "./screens/Management";

export const router = createBrowserRouter([
  {
    path: "/login",
    Component: Login,
  },
  {
    path: "/",
    Component: Root,
    children: [
      { index: true, Component: Home },
      { path: "home", Component: Home },
      { path: "schedule", Component: Schedule },
      { path: "members", Component: Members },
      { path: "members/:id", Component: MemberProfile },
      { path: "requests", Component: PTRequests },
      { path: "chat", Component: Chat },
      { path: "chat/:memberId", Component: Chat },
      { path: "time", Component: TimeTracking },
      { path: "attendance", Component: Attendance },
      { path: "notifications", Component: Notifications },
      { path: "management", Component: Management },
    ],
  },
]);

import express from "express";
import cookieParser from "cookie-parser";
import { PrismaClient } from "@prisma/client";
import { betterAuth } from "better-auth";
import { PrismaAdapter } from "better-auth/adapters/prisma";

const prisma = new PrismaClient();

const auth = betterAuth({
  adapter: PrismaAdapter({ prisma }),
  emailAndPassword: {
    enabled: true,
    requireEmailConfirmation: true,
    resetPassword: true
  },
  email: {
    sendVerification: true,
    sendReset: true,
    transporter: {
      host: process.env.SMTP_HOST,
      port: Number(process.env.SMTP_PORT),
      secure: false,
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS
      }
    },
    from: process.env.EMAIL_FROM
  },
  session: {
    cookieName: "central_auth_session",
    maxAge: 1000 * 60 * 60 * 24 * 7, // 7 days
    secure: process.env.NODE_ENV === "production"
  },
  urls: {
    appUrl: process.env.APP_URL, // frontend or auth domain
    apiBase: "/auth"
  }
});

const app = express();
app.use(express.json());
app.use(cookieParser());

// Mount Better Auth router
app.use("/auth", auth.router);

// Health check
app.get("/_health", (req, res) => res.json({ ok: true }));

// Protected profile route example
app.get("/auth/profile", async (req, res) => {
  const session = await auth.getSession(req, res);
  if (!session) return res.status(401).json({ error: "unauthenticated" });
  const user = await prisma.user.findUnique({
    where: { id: session.userId },
    select: { id: true, email: true, name: true, image: true, isVerified: true, createdAt: true }
  });
  res.json({ user });
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Central Auth server running on port ${PORT}`);
});

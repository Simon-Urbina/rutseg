async function sendRawEmail(to: string, subject: string, html: string): Promise<void> {
  const apiKey = process.env.BREVO_API_KEY
  const senderEmail = process.env.BREVO_SENDER_EMAIL
  if (!apiKey || !senderEmail)
    throw new Error('BREVO_API_KEY y BREVO_SENDER_EMAIL son requeridos')

  const res = await fetch('https://api.brevo.com/v3/smtp/email', {
    method: 'POST',
    headers: {
      'api-key': apiKey,
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
    body: JSON.stringify({
      sender: { name: 'RutSeg', email: senderEmail },
      to: [{ email: to }],
      subject,
      htmlContent: html,
    }),
  })

  if (!res.ok) {
    const body = await res.text()
    throw new Error(`Brevo API error ${res.status}: ${body}`)
  }
}

// ─── Funciones auxiliares de maquetado ────────────────────────────────────────

function emailHeader(title: string, subtitle: string): string {
  return `
    <div style="background:#0A1545;padding:28px 36px">
      <table cellpadding="0" cellspacing="0" border="0">
        <tr>
          <td style="width:44px;height:44px;background:#1A3F96;border-radius:10px;text-align:center;vertical-align:middle;font-size:22px">
            🔐
          </td>
          <td style="padding-left:14px;vertical-align:middle">
            <div style="color:#F5C500;font-family:'Segoe UI',Arial,sans-serif;font-size:19px;font-weight:700;letter-spacing:0.04em;line-height:1.2">RutSeg</div>
            <div style="color:#3A5AB8;font-family:'Courier New',monospace;font-size:10px;letter-spacing:0.14em;text-transform:uppercase;margin-top:3px">// plataforma de aprendizaje</div>
          </td>
        </tr>
      </table>
    </div>
    <div style="height:3px;background:linear-gradient(90deg,#F5C500 0%,#2596be 100%);font-size:0;line-height:0">&nbsp;</div>
    <div style="background:#ffffff;padding:36px 36px 8px">
      <h2 style="margin:0 0 12px;font-size:22px;color:#0A1545;font-family:'Segoe UI',Arial,sans-serif;font-weight:700">${title}</h2>
      <p style="margin:0 0 24px;color:#6b7280;font-size:11px;font-family:'Courier New',monospace;letter-spacing:0.1em;text-transform:uppercase">${subtitle}</p>
    </div>
  `
}

function emailFooter(note: string): string {
  return `
    <div style="background:#ffffff;padding:0 36px 28px">
      <div style="height:1px;background:#E8EEFA;margin-bottom:20px"></div>
      <p style="color:#9CA3AF;font-size:12px;font-family:'Segoe UI',Arial,sans-serif;margin:0;line-height:1.7">
        ${note}
      </p>
    </div>
    <div style="background:#060D1F;padding:14px 36px;text-align:center">
      <span style="color:#3A5AB8;font-size:11px;font-family:'Courier New',monospace;letter-spacing:0.1em">rutseg.vercel.app</span>
    </div>
  `
}

// ─── Emails ───────────────────────────────────────────────────────────────────

export async function sendVerificationEmail(to: string, username: string, code: string): Promise<void> {
  const html = `
    <div style="background:#EEF3FC;padding:32px 16px;font-family:'Segoe UI',Arial,sans-serif">
      <div style="max-width:520px;margin:0 auto;border-radius:16px;overflow:hidden;box-shadow:0 4px 32px rgba(10,21,69,0.12)">
        ${emailHeader('Verificación de correo', '// activa tu cuenta')}
        <div style="background:#ffffff;padding:0 36px 8px">
          <p style="color:#374151;line-height:1.7;font-size:15px;font-family:'Segoe UI',Arial,sans-serif;margin:0 0 28px">
            Hola <strong style="color:#0A1545">${username}</strong>, gracias por unirte a RutSeg.<br/>
            Ingresa el siguiente código en la plataforma para activar tu cuenta.
            Expira en <strong>15 minutos</strong>.
          </p>
          <div style="margin:0 0 28px;padding:24px 32px;background:#f0f4ff;border-radius:12px;text-align:center;border:1px solid rgba(26,63,150,0.18)">
            <div style="letter-spacing:0.45em;font-size:38px;font-weight:700;font-family:'Courier New',monospace;color:#0A1545;line-height:1">${code}</div>
            <div style="color:#1A3F96;font-size:11px;font-family:'Courier New',monospace;letter-spacing:0.1em;margin-top:10px;text-transform:uppercase">código de verificación</div>
          </div>
        </div>
        ${emailFooter('Si no creaste esta cuenta en RutSeg, puedes ignorar este correo de forma segura.')}
      </div>
    </div>
  `

  await sendRawEmail(to, 'Verifica tu correo — RutSeg', html)
}

export async function sendPasswordResetEmail(to: string, resetLink: string): Promise<void> {
  const html = `
    <div style="background:#EEF3FC;padding:32px 16px;font-family:'Segoe UI',Arial,sans-serif">
      <div style="max-width:520px;margin:0 auto;border-radius:16px;overflow:hidden;box-shadow:0 4px 32px rgba(10,21,69,0.12)">
        ${emailHeader('Restablecer contraseña', '// solicitud de cambio')}
        <div style="background:#ffffff;padding:0 36px 8px">
          <p style="color:#374151;line-height:1.7;font-size:15px;font-family:'Segoe UI',Arial,sans-serif;margin:0 0 28px">
            Recibimos una solicitud para restablecer la contraseña de tu cuenta en
            <strong style="color:#0A1545">RutSeg</strong>.
            Haz clic en el botón para continuar. El enlace expira en <strong>1 hora</strong>.
          </p>
          <table cellpadding="0" cellspacing="0" border="0" style="margin-bottom:28px">
            <tr>
              <td style="border-radius:10px;background:#F5C500">
                <a href="${resetLink}"
                   style="display:inline-block;padding:14px 32px;color:#0A1545;text-decoration:none;font-family:'Segoe UI',Arial,sans-serif;font-weight:700;font-size:15px;border-radius:10px;letter-spacing:0.02em">
                  Restablecer contraseña →
                </a>
              </td>
            </tr>
          </table>
        </div>
        ${emailFooter('Si no solicitaste este cambio, puedes ignorar este correo. Tu contraseña permanecerá igual.')}
      </div>
    </div>
  `

  await sendRawEmail(to, 'Restablece tu contraseña — RutSeg', html)
}

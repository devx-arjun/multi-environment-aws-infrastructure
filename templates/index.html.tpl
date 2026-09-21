<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${project_name} — ${environment}</title>

  <style>
    * {
      box-sizing: border-box;
    }

    body {
      margin: 0;
      min-height: 100vh;
      padding: 24px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      background: #0f1115;
      color: #e6e6e6;
    }

    .card {
      width: 100%;
      max-width: 640px;
      padding: 40px;
      background: #171a21;
      border: 1px solid #262a33;
      border-radius: 16px;
      box-shadow: 0 20px 60px rgba(0, 0, 0, 0.4);
    }

    .badge {
      display: inline-block;
      padding: 6px 14px;
      margin-bottom: 20px;
      border-radius: 999px;
      background: ${environment == "prod" ? "#ff5c5c" : "#3ddc84"};
      color: #0f1115;
      font-size: 12px;
      font-weight: 700;
      letter-spacing: 0.08em;
      text-transform: uppercase;
    }

    h1 {
      margin: 0 0 6px;
      font-size: 28px;
    }

    .sub {
      margin-bottom: 28px;
      color: #9099a8;
      font-size: 14px;
    }

    .grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 16px;
    }

    .stat {
      padding: 14px 16px;
      background: #0f1115;
      border: 1px solid #262a33;
      border-radius: 10px;
    }

    .label {
      margin-bottom: 4px;
      color: #9099a8;
      font-size: 12px;
      letter-spacing: 0.05em;
      text-transform: uppercase;
    }

    .value {
      font-size: 16px;
      font-weight: 600;
      word-break: break-word;
    }

    .footer {
      margin-top: 28px;
      color: #565f6f;
      font-size: 12px;
      text-align: center;
    }

    .pulse {
      display: inline-block;
      width: 8px;
      height: 8px;
      margin-right: 8px;
      border-radius: 50%;
      background: #3ddc84;
      animation: pulse 2s infinite;
    }

    @keyframes pulse {
      0% {
        box-shadow: 0 0 0 0 rgba(61, 220, 132, 0.6);
      }

      70% {
        box-shadow: 0 0 0 8px rgba(61, 220, 132, 0);
      }

      100% {
        box-shadow: 0 0 0 0 rgba(61, 220, 132, 0);
      }
    }

    @media (max-width: 600px) {
      .card {
        padding: 28px;
      }

      .grid {
        grid-template-columns: 1fr;
      }
    }
  </style>
</head>

<body>
  <div class="card">

    <span class="badge">${environment}</span>

    <h1>${project_name}</h1>

    <div class="sub">
      <span class="pulse"></span>
      Instance ${instance_index} of ${instance_count} — live
    </div>

    <div class="grid">

      <div class="stat">
        <div class="label">Environment</div>
        <div class="value">${environment}</div>
      </div>

      <div class="stat">
        <div class="label">Instance Type</div>
        <div class="value">${instance_type}</div>
      </div>

      <div class="stat">
        <div class="label">Availability Zone</div>
        <div class="value">${availability_zone}</div>
      </div>

      <div class="stat">
        <div class="label">Region</div>
        <div class="value">${aws_region}</div>
      </div>

      <div class="stat">
        <div class="label">Total Instances</div>
        <div class="value">${instance_count}</div>
      </div>

      <div class="stat">
        <div class="label">Deployment</div>
        <div class="value">Terraform</div>
      </div>

    </div>

    <div class="footer">
      Provisioned by Terraform · workspace: ${environment}
    </div>

  </div>
</body>
</html>
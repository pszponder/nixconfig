#!/usr/bin/env bash
set -euo pipefail

finger="${1:-right-index-finger}"

if [[ $EUID -eq 0 ]]; then
	echo "Run as your regular user without sudo to enroll your own fingerprint." >&2
	exit 1
fi
if ! command -v fprintd-enroll >/dev/null || ! command -v fprintd-verify >/dev/null; then
	echo "Activate a host configuration with the fingerprint feature first: just switch" >&2
	exit 1
fi

printf '\nEnrolling your %s.\n' "${finger//-/ }"
cat <<'EOF'
If GNOME asks for your password, approve enrollment, then return to this terminal.
Repeatedly touch the reader with the same finger and lift it fully between scans.
Vary the angle slightly so the reader captures different parts of your fingertip.
"enroll-stage-passed" means one scan succeeded: keep going.
Wait for "enroll-completed"; there is no separate graphical setup window.
Press Ctrl+C to cancel.

EOF
if ! fprintd-enroll -f "$finger"; then
	echo "Enrollment did not complete. Run just fingerprint-setup again to retry." >&2
	exit 1
fi

printf '\nVerification: lift your finger, then touch the reader again with your %s.\n' "${finger//-/ }"
echo 'Look for "verify-match" to confirm that verification succeeded.'
if ! fprintd-verify -f "$finger"; then
	echo "Verification failed. Retry with: fprintd-verify -f $finger" >&2
	exit 1
fi

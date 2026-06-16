import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Stack,
  TextField,
} from "@mui/material";

import {
  useEffect,
  useState,
} from "react";

import { kioskService } from "../../../services/kioskService";
import { notify } from "../../../utils/toast";

interface Props {
  open: boolean;
  kiosk?: any | null;
  onClose: () => void;
  onSuccess: () => void;
}

export default function KioskFormDialog({
  open,
  kiosk,
  onClose,
  onSuccess,
}: Props) {
  const [kioskCode, setKioskCode] =
    useState("");

  const [name, setName] =
    useState("");

  const [location, setLocation] =
    useState("");

  const [secretKey, setSecretKey] =
    useState("");

  useEffect(() => {
    if (kiosk) {
      setKioskCode(
        kiosk.kiosk_code ?? ""
      );

      setName(
        kiosk.name ?? ""
      );

      setLocation(
        kiosk.location ?? ""
      );

      setSecretKey(
        kiosk.secret_key ?? ""
      );
    } else {
      setKioskCode("");
      setName("");
      setLocation("");
      setSecretKey("");
    }
  }, [kiosk, open]);

  const handleSave = async () => {
    const payload = {
      kiosk_code: kioskCode,
      name,
      location,
      secret_key: secretKey,
    };

    if (kiosk) {
      await kioskService.update(
        kiosk.id,
        payload
      );

      notify.success(
        "Kiosk updated"
      );
    } else {
      await kioskService.create(
        payload
      );

      notify.success(
        "Kiosk created"
      );
    }

    onSuccess();
    onClose();
  };

  return (
    <Dialog
      open={open}
      onClose={onClose}
      fullWidth
      maxWidth="sm"
    >
      <DialogTitle>
        {kiosk
          ? "Edit Kiosk"
          : "Create Kiosk"}
      </DialogTitle>

      <DialogContent>
        <Stack
          spacing={2}
          sx={{ mt: 1 }}
        >
          <TextField
            label="Kiosk Code"
            value={kioskCode}
            onChange={(e) =>
              setKioskCode(
                e.target.value
              )
            }
          />

          <TextField
            label="Name"
            value={name}
            onChange={(e) =>
              setName(
                e.target.value
              )
            }
          />

          <TextField
            label="Location"
            value={location}
            onChange={(e) =>
              setLocation(
                e.target.value
              )
            }
          />

          <TextField
            label="Secret Key"
            value={secretKey}
            onChange={(e) =>
              setSecretKey(
                e.target.value
              )
            }
          />
        </Stack>
      </DialogContent>

      <DialogActions>
        <Button onClick={onClose}>
          Cancel
        </Button>

        <Button
          variant="contained"
          onClick={handleSave}
        >
          {kiosk
            ? "Update"
            : "Save"}
        </Button>
      </DialogActions>
    </Dialog>
  );
}

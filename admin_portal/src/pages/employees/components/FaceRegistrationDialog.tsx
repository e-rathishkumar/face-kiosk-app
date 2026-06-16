import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  MenuItem,
  TextField
} from "@mui/material";

import { useState } from "react";

import { employeeService } from "../../../services/employeeService";

interface Props {
  open: boolean;
  employeeId: string;
  onClose: () => void;
}

export default function FaceRegistrationDialog({
  open,
  employeeId,
  onClose
}: Props) {

  const [file, setFile] =
    useState<File>();

  const [pose, setPose] =
    useState("FRONT");

  const uploadFace = async () => {

    if (!file) return;

    await employeeService.uploadFace(
      employeeId,
      pose,
      file
    );

    onClose();
  };

  return (
    <Dialog
      open={open}
      maxWidth="sm"
      fullWidth
    >
      <DialogTitle>
        Register Face
      </DialogTitle>

      <DialogContent>

        <TextField
          select
          fullWidth
          sx={{ mb: 2 }}
          value={pose}
          onChange={(e) =>
            setPose(
              e.target.value
            )
          }
        >
          <MenuItem value="FRONT">
            FRONT
          </MenuItem>

          <MenuItem value="LEFT">
            LEFT
          </MenuItem>

          <MenuItem value="RIGHT">
            RIGHT
          </MenuItem>

          <MenuItem value="UP">
            UP
          </MenuItem>

          <MenuItem value="DOWN">
            DOWN
          </MenuItem>

          <MenuItem value="FRONT_LEFT">
            FRONT_LEFT
          </MenuItem>

          <MenuItem value="FRONT_RIGHT">
            FRONT_RIGHT
          </MenuItem>
        </TextField>

        <input
          type="file"
          accept="image/*"
          onChange={(e) =>
            setFile(
              e.target.files?.[0]
            )
          }
        />

      </DialogContent>

      <DialogActions>

        <Button
          onClick={onClose}
        >
          Cancel
        </Button>

        <Button
          variant="contained"
          onClick={uploadFace}
        >
          Upload
        </Button>

      </DialogActions>
    </Dialog>
  );
}

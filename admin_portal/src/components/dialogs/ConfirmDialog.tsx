import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Typography,
} from "@mui/material";

interface Props {
  open: boolean;
  title: string;
  message: string;
  onConfirm: () => void;
  onClose: () => void;
}

export default function ConfirmDialog({
  open,
  title,
  message,
  onConfirm,
  onClose,
}: Props) {
  return (
    <Dialog
      open={open}
      onClose={onClose}
      maxWidth="xs"
      fullWidth
    >
      <DialogTitle>
        {title}
      </DialogTitle>

      <DialogContent>
        <Typography>
          {message}
        </Typography>
      </DialogContent>

      <DialogActions>
        <Button onClick={onClose}>
          Cancel
        </Button>

        <Button
          color="error"
          variant="contained"
          onClick={onConfirm}
        >
          Confirm
        </Button>
      </DialogActions>
    </Dialog>
  );
}

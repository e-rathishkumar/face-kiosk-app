from insightface.app import FaceAnalysis


class InsightFaceService:

    app = FaceAnalysis(
        name="buffalo_l",
        allowed_modules=['detection', 'recognition']
    )

    app.prepare(
        ctx_id=-1,
        det_size=(160, 160),
        det_thresh=0.3
    )
